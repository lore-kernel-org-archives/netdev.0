From: David Dillow <dave@thedillows.org>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 11:34:52 -0500
Message-ID: <1358699692.2494.29.camel@obelisk.thedillows.org>
References: <2012247681.93123.1358694444237.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2012247681.93123.1358694444237.JavaMail.root@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-01-20 at 10:07 -0500, Tom St Denis wrote:
> In all likelihood I will submit a revised CMAC patch but it'll take
> time before I can get business hours to work on it.  So instead of
> having a maintainer just touch it up we're all going to lose out
> because of pride?

Yes -- but it would seem to be yours that presents the problem.

I'm sure you could have fixed your patch up in the amount of time you've
spent railing against the push-back. How much of that were you billing
for, and is that a productive use your employer's money? Even on your
own time, how productive has that been? Do you feel better, having
vented?

You don't think the maintainers are maintaining if they don't clean up
after every random contributor -- fine, call them lieutenants then.
Their job is to guide the new development towards the goals for the
system, review patches, and develop new features.

You'll notice I didn't say "reformat code when standards change." This
is a distributed project and it doesn't scale to have the code
continually in flux -- reformatting creates conflicts in other
contributors patches, which then consume all of a lieutenant's time if
they were to try to fix up each one for them. It's much better to push
push that work out to the edge of the network -- put another way, "many
hands make light work." Fixing existing formatting problems is
acceptable in a patch series if one is working in the area, but it is
rare that a series devoted solely to that kind of cleanup gets in.

The coding styles have evolved over time, and are different for
different areas of the kernel -- for example, most of the kernel wants
'/*' on its own line for a multi-line comment, but under net/ it should
not. You should try to match the style in your area -- claiming that the
cryto/ code does it one way is unlikely to sway opinion in net/.
Different lieutenants, different opinions.

As for the existing style issues in net/ipv4/ah4.c you posted, no, your
patch adding a feature in ah4 would probably not been rejected because
of the existing issues, though if one was in the middle of your changes,
it is possible that your would be asked to fix it. As for the issues
checkpatch.pl found, they are in many cases legitimate, but are also the
exceptions -- there are plenty of counter-examples in that file showing
the preferred style.

All the best for your future endeavors,
Dave
