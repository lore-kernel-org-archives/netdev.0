From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [V4.4-rc6 Regression] af_unix: Revert 'lock_interruptible' in stream receive code
Date: Sun, 07 Feb 2016 20:39:02 +0000
Message-ID: <8760y0l0gp.fsf@doppelsaurus.mobileactivedefense.com>
References: <56B4EF04.2060407@canonical.com>
	<87bn7ude8g.fsf@doppelsaurus.mobileactivedefense.com>
	<1454713398.7627.325.camel@edumazet-glaptop2.roam.corp.google.com>
	<8737t4jr99.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	davem@davemloft.net, hannes@stressinduktion.org,
	edumazet@google.com, dhowells@redhat.com, ying.xue@windriver.com,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable\@vger.kernel.org" <stable@vger.kernel.org>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <8737t4jr99.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Sun, 07 Feb 2016 18:43:14 +0000")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:

[...]

> the real problem is that the function disagrees with itself on how to
> use the err variable: The start uses that to record an error which
> might need to be reported, the return statement uses it to indicate
> that an error has occurred.

This should have been "as indication that an errors has occured" (if no
data was copied).
