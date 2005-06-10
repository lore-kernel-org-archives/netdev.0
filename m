From: Lee Revell <rlrevell@joe-job.com>
Subject: RE: ipw2100: firmware problem
Date: Fri, 10 Jun 2005 17:07:18 -0400
Message-ID: <1118437639.6423.65.camel@mindpipe>
References: <003001c56dff$662fe4b0$600cc60a@amer.sykes.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'Netdev list'" <netdev@oss.sgi.com>,
        "'kernel list'" <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: abonilla@linuxwireless.org
In-Reply-To: <003001c56dff$662fe4b0$600cc60a@amer.sykes.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-10 at 15:00 -0600, Alejandro Bonilla wrote:
> > > It thing of Mute in ALSA is stupid. If you want Sound, you
> > install the Sound
> > > and enable it. Why would it make you google for more things
> > to do? ALSA mute
> > > on install is WAY way, not OK.
> >
> > It took you 10 minutes of googling before you thought to try
> > the mixer?
> > Sorry dude, this is PEBKAC.
> >
> > Lee
> 
> Riiiight. It could be. Or it could be that no where in the world I have seen
> something where the device would be disabled by default without notifying
> the user. Why would you Mute the driver? Is the driver that bad, that the
> developers would rather Mute the sound card, just in case if the sound cards
> starts making noises and shit when the driver is loaded?
> 

Userspace should handle it, doing this in the kernel is bloat.

My Debian system initializes the mixer settings to a sane state just
fine when the alsasound init script is run.  Maybe you need a better
distro.

Users who compile ALSA from source are expected to know what they are
doing.  And, if you watch the "make install" output, it prints a big fat
warning that all mixer controls are muted by default.

> You are moving to another topic. Let's drop it.

Agreed, but it was your OT rant that changed the topic...

Lee
