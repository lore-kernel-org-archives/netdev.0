From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Subject: Re: [2.6.16-gitX] heavy performance regression in ipw2200 wireless driver
Date: Sat, 25 Mar 2006 23:48:29 +0100
Message-ID: <5a4c581d0603251448k1df0c7bdob1f7a2a39749a8be@mail.gmail.com>
References: <5a4c581d0603221724m391f5466l8a2af3ae7f0aacae@mail.gmail.com>
	 <20060322191057.304962a4.akpm@osdl.org>
	 <5a4c581d0603230602s1a868a4apbfd79ec2bc568011@mail.gmail.com>
	 <1143171674.17270.195.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andrew Morton" <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	"James Ketrenos" <jketreno@linux.intel.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751961AbWCYWsb@vger.kernel.org>
To: "Zhu Yi" <yi.zhu@intel.com>
In-Reply-To: <1143171674.17270.195.camel@debian.sh.intel.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/24/06, Zhu Yi <yi.zhu@intel.com> wrote:
> On Thu, 2006-03-23 at 15:02 +0100, Alessandro Suardi wrote:
> > That scp test shows 50%ish - but that was a quickie. The VNC
> >  client even reported a 719Kbps throughput down from the more
> >  usual 11500Kbps it starts off with. The first scp I tried when the
> >  sluggishness was intolerable was going at 200KB/s - which
> >  shows the problem can easily get in the neighborhood of an
> >  order of magnitude.
>
> What kind of wireless encryption do you use? We turned off hardware
> encryption by default recently as a workaround for a firmware restart
> bug. You might want to load module with "modprobe ipw2200 hwcrypto=1"
> and retest.

The issue seems to have vanished in more recent kernel snapshots
 (namely, 2.6.16-git3 and -git5 exhibited the problem; -git8 and -git9
 did not).

I will holler if the problem pops up again... thanks,

--alessandro

 "Dreamer ? Each one of us is a dreamer. We just push it down deep because
   we are repeatedly told that we are not allowed to dream in real life"
     (Reinhold Ziegler)
