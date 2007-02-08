From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2/3] X.25: Adds /proc/sys/net/x25/x25_forward to control forwarding.
Date: Thu, 8 Feb 2007 23:22:11 +0300
Message-ID: <20070208202211.GB5532@martell.zuzino.mipt.ru>
References: <1170890071.5189.40.camel@localhost> <20070208201909.GA5532@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-x25@vger.kernel.org, eis@baty.hanse.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ahendry <ahendry@tusc.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423307AbXBHUWP@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070208201909.GA5532@martell.zuzino.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 08, 2007 at 11:19:09PM +0300, Alexey Dobriyan wrote:
> On Thu, Feb 08, 2007 at 10:14:31AM +1100, ahendry wrote:
> > echo "1" > /proc/sys/net/x25/x25_forward
> > To turn on x25_forwarding, defaults to off
> 
> > --- linux-2.6.20-vanilla/include/linux/sysctl.h
> > +++ linux-2.6.20/include/linux/sysctl.h
> > @@ -699,7 +699,8 @@ enum {
> >  	NET_X25_CALL_REQUEST_TIMEOUT=2,
> >  	NET_X25_RESET_REQUEST_TIMEOUT=3,
> >  	NET_X25_CLEAR_REQUEST_TIMEOUT=4,
> > -	NET_X25_ACK_HOLD_BACK_TIMEOUT=5
> > +	NET_X25_ACK_HOLD_BACK_TIMEOUT=5,
> > +	NET_X25_FORWARD=6
> >  };
> 
> > --- linux-2.6.20-vanilla/net/x25/sysctl_net_x25.c
> > +++ linux-2.6.20/net/x25/sysctl_net_x25.c
> > @@ -73,6 +73,14 @@ static struct ctl_table x25_table[] = {
> >  		.extra1 =	&min_timer,
> >  		.extra2 =	&max_timer,
> >  	},
> > +	{
> > +		.ctl_name =	NET_X25_FORWARD,
> > +		.procname =	"x25_forward",
> > +		.data = 	&sysctl_x25_forward,
> > +		.maxlen = 	sizeof(int),
> > +		.mode = 	0644,
> > +		.proc_handler = &proc_dointvec,
> > +	},
> 
> Reserving binary sysctl number and not defining ->strategy is strange.

Ouch, please, ignore. I misparsed sysctl code.
