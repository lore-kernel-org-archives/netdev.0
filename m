From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 11:44:45 -0800
Message-ID: <200502121945.j1CJjWDD016296@guinness.s2io.com>
References: <20050212112811.13a0b97d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <rick.jones2@hp.com>, <hubert.tonneau@fullpliant.org>,
        <shemminger@osdl.org>, <romieu@fr.zoreil.com>, <kuznet@ms2.inr.ac.ru>,
        <netdev@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>,
        "'Alexey Kuznetsov'" <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050212112811.13a0b97d.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Typically, a TSO engine sets PSH in the last packet that it builds for the
TSO+PSH request.
Leonid

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of David S. Miller
> Sent: Saturday, February 12, 2005 11:28 AM
> To: Alexey Kuznetsov
> Cc: rick.jones2@hp.com; hubert.tonneau@fullpliant.org; 
> shemminger@osdl.org; romieu@fr.zoreil.com; 
> kuznet@ms2.inr.ac.ru; netdev@oss.sgi.com
> Subject: Re: 2.6.10 TCP troubles -- suggested patch
> 
> On Sat, 12 Feb 2005 17:31:05 +0300
> Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> 
> > In any case, receiver cannot know sender cwnd, so that 
> "fill" or "not fill"
> > is is not a question.
> >
> > What is broken in that implementation is that it does not 
> feel slow start.
> > ACK avoidance while slow start is certain disaster. 
> Currrent theory is 
> > that MacOS X thinks that we do not do slow start.
> 
> It is correct.  Although, I am still believing that setting 
> PSH is the avenue of investigation.
> 
> 
