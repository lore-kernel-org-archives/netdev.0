From: Dan Kegel <dank@kegel.com>
Subject: Re: comment on [NET]: Delete support for old-style protocols, no
 longer necessary.
Date: Tue, 07 Oct 2003 17:22:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F8358CA.1010101@kegel.com>
References: <1065551829.2340.9.camel@localhost.localdomain>	 <20031007115244.14a887ed.davem@redhat.com> <1065569620.2340.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David S Miller <davem@redhat.com>, davem@nuts.ninka.net,
        linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>
In-Reply-To: <1065569620.2340.19.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
>>>-       void                    *af_packet_priv;
>>>+       struct sock             *sk;	/* appropriate comment: socket copy? */
>>
>>AF_PACKET is the only user of this private field, and
>>I want people to be aware of this and not try to use it
>>for other stuff.
>>
>>Nobody else can use it for something different, the code
>>in net/core/dev.c does specific things when it's non-NULL
>>knowing that this non-NULL value means that it's an
>>AF_PACKET packet_type being passed to it.
>>
>>So we won't make your suggested change.
> 
> Even so, why not call it a struct sock*?
> It is after all and is used as one.

To discourage other modules from using it, and to keep
programmers who aren't working on AF_PACKET from thinking about it.
It's SOP to use opaque cookies when you want to make data private.
- Dan

-- 
Dan Kegel
http://www.kegel.com
http://counter.li.org/cgi-bin/runscript/display-person.cgi?user=78045
