From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 11:26:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <60449712.1031311608@[10.10.2.3]>
References: <E17nNhM-0003PD-00@w-gerrit2>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tcw@tempest.prismnet.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gerrit Huizenga <gh@us.ibm.com>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <E17nNhM-0003PD-00@w-gerrit2>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>    One of our goals is to actually take the next generation of the most
>>    common "large system" web server and get it to scale along the lines
>>    of Tux or some of the other servers which are more common on the
>>    small machines.  For some reasons, big corporate customers want lots
>>    of features that are in a web server like apache and would also like
>>    the performance on their 8-CPU or 16-CPU machine to not suck at the
>>    same time.  High ideals, I know, wanting all features *and* performance
>>    from the same tool...  Next thing you know they'll want reliability
>>    or some such thing.
>> 
>> Why does Tux keep you from taking advantage of all the
>> feature of Apache?  Anything Tux doesn't handle in it's
>> fast path is simple fed up to Apache.
> 
> You have to ask the hard questions...   

Ultimately, to me at least, the server doesn't really matter, and
neither do the absolute benchmark numbers. Linux should scale under 
any reasonable workload. The point of this is to look at the Linux
kernel, not the webserver, or specweb ... they're just hammers to
beat on the kernel with.

The fact that we're doing something different from everyone else
and turning up a different set of kernel issues is a good thing, 
to my mind. You're right, we could use Tux if we wanted to ... but
that doesn't stop Apache being interesting ;-)

M.
