From: Jan Rychter <jan@rychter.com>
Subject: Re: ipw2100: firmware problem
Date: Mon, 13 Jun 2005 18:42:52 +0200
Message-ID: <m2slzmmcmr.fsf@tnuctip.rychter.com>
References: <000f01c56dbf$9b15de90$600cc60a@amer.sykes.com>
	<1118435188.6423.26.camel@mindpipe>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261663AbVFMQEJ@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Lee" == Lee Revell <rlrevell@joe-job.com> writes:
 Lee> On Fri, 2005-06-10 at 07:23 -0600, Alejandro Bonilla wrote:
 >> >
 >> > Adding kernel level wireless autoconfiguration duplicates the
 >> > effort.  Since I am not going to give up a requirement to be able
 >> > to stay radio silent at boot (me too wants freedom, not only you),
 >> > you need to add disable=1 module parameter to each driver, which
 >> > adds to the mess.
 >> >
 >> > ALSA does the Right Thing. Sound is completely muted out at module
 >> > load.  It's a user freedom to set desired volume level after that.
 >>
 >> Yeah right. I remember I had to google for 10 minutes to find the
 >> answer for this one. Why would you install something, for it to not
 >> work?
 >>
 >> It thing of Mute in ALSA is stupid. If you want Sound, you install
 >> the Sound and enable it. Why would it make you google for more
 >> things to do? ALSA mute on install is WAY way, not OK.

 Lee> It took you 10 minutes of googling before you thought to try the
 Lee> mixer?  Sorry dude, this is PEBKAC.

Oh, really, you think this works so well? Ever tried to use more than
one soundcard? A USB audio device? Ever wondered why oh why one has to
always check and twiddle with the mixers? Why (it seems) setting the
volume of USB audio devices via alsamixer doesn't work for apps which
use OSS emulation? Ever wondered why alsactl restore doesn't get called
by udev by default?

The current Linux approach (most distributions) is to let the user be
the master. Which means lots of typing, configuring, tweaking. Try that
on a tablet pc without a keyboard.

Things should Just Work. I wish most Linux developers tried using a Mac
at least once in their lifetimes.

--J.
