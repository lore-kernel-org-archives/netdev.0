From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 18:04:10 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625.180410.74717146.davem@redhat.com>
References: <1056547262.1945.1436.camel@brick.watson.ibm.com>
	<20030625.143334.85380461.davem@redhat.com>
	<1056578813.27267.8.camel@brick.watson.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, paulus@samba.org, netdev@oss.sgi.com,
   fcusack@samba.org, carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mostrows@watson.ibm.com
In-Reply-To: <1056578813.27267.8.camel@brick.watson.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Michal Ostrowski <mostrows@watson.ibm.com>
   Date: 25 Jun 2003 18:06:54 -0400

   Exactly this mechanism is what I had in mind.  
   
Great.

   The open question remaining is if there are any protocols which can be
   affected by packets being processed out of order.  Some people have
   suggested that there are.  If not, then there's not much to discuss. Can
   anyone comment on this decisively, either way?

TCP, as one example, is able to cope very well.  It is even able to
distinguish reordering from true packet loss.
