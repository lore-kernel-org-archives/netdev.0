From: Michal Ostrowski <mostrows@watson.ibm.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: 25 Jun 2003 18:06:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056578813.27267.8.camel@brick.watson.ibm.com>
References: <20030625072602.529AF2C0B9@lists.samba.org>
	 <1056547262.1945.1436.camel@brick.watson.ibm.com>
	 <20030625.143334.85380461.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, Paul MacKerras <paulus@samba.org>,
   netdev@oss.sgi.com, fcusack@samba.org, carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030625.143334.85380461.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-06-25 at 17:33, David S. Miller wrote:
> Why don't you just queue the payload packets in a "resolution queue"
> until the socket is created?  Just make the resolution queue packets
> timeout using a value that will easily exceed any reasonable PPP
> negotiation time.
> 
> All this ordered packet arrival shit is just beyond stupid.

Exactly this mechanism is what I had in mind.  

The open question remaining is if there are any protocols which can be
affected by packets being processed out of order.  Some people have
suggested that there are.  If not, then there's not much to discuss. Can
anyone comment on this decisively, either way?



-- 
Michal Ostrowski <mostrows@watson.ibm.com>
