From: "Jeff Kirsher" <tarbal@gmail.com>
Subject: Re: mii-tool gigabit support.
Date: Wed, 27 Sep 2006 09:20:00 -0700
Message-ID: <9929d2390609270920r288c11f8s41783ec3ce629bb@mail.gmail.com>
References: <20060926145113.7a6791c8@freekitty> <4519A1D6.1050802@pobox.com>
	 <20060926150947.3d538547@freekitty> <451A7603.1030204@roinet.com>
	 <451A9201.6000600@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Acker" <dacker@roinet.com>,
	"Stephen Hemminger" <shemminger@osdl.org>,
	"Jeff Garzik" <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:24533 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751210AbWI0QUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 12:20:04 -0400
Received: by py-out-1112.google.com with SMTP id n25so354411pyg
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2006 09:20:04 -0700 (PDT)
To: "Auke Kok" <auke-jan.h.kok@intel.com>
In-Reply-To: <451A9201.6000600@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/27/06, Auke Kok <auke-jan.h.kok@intel.com> wrote:
> David Acker wrote:
> >
> > mii-tool supports some things that ethtool does not.  mii-tool -A lets
> > you set the advertised speeds and can include a list of speeds.  The
> > closest ethtool seems to have is ethtool -s but that seems to just set
> > the advertised speed to a single value only.
>
> We sent a patch for this to Jeff recently that allows setting of 'arbitrary'
> speeds. Unfortunately the interface is rather crude but it works (for e1000,
> and possibly all other nics) to set any combination of advertised speeds.
>
> e.g. `ethtool -s eth0 advertise 0x0f` advertises all non-gigabit speeds
>
> I haven't seen the patch merged yet upstream though.
>
> Cheers,
>
> Auke
>
> >
> > We have instances where we want to limit the link of the ethernet port
> > to no higher then 10 Mbps full duplex but also advertise support for
> > half duplex.
> >
> > With mii-tool we can do the command below and work with a half duplex
> > hub and a full duplex switch.
> > mii-tool -A 10baseT-FD,10baseT-HD eth0
> >
> > Meanwhile if I use ethtool like the command below I will not work with a
> > half duplex only hub.
> > ethtool -s eth0 speed 10 duplex full autoneg on
> >
> > Perhaps the "speed" part of ethtool -s should take a list of speeds like
> > mii-tool does.
> >
> > -Ack

Garzik has ACK and pulled in the ethtool patch which allows you to set
multiple auto-negotiation advertised speeds.

-- 
Cheers,
Jeff
