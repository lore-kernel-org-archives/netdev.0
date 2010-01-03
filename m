From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC 0/9] snet: Security for NETwork syscalls
Date: Sun, 03 Jan 2010 11:57:52 -0500
Message-ID: <1262537872.10218.27.camel@bigi>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1262437456-24476-1-git-send-email-sam@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Samir,

This fills in a gap i always thought was missing from LSM's 
boolean verdict policies. So good effort.

1)I would love to see the send/recvmsg interface complete (seems
missing).
2) If you can provide an async scheme which allows re-injection of
policy verdicts in addition to the sync interface, i think that would be
more valuable. I can see many apps which collect multiple states before
making a policy decision on multiple messages (example a multipart
message). Is SNET_VERDICT_PENDING intended for this?

A small glitch i noticed; you have defines in patches 8 and 9 which are
needed by patches 6 and 7. I think the general idea should be to compile
after adding each patch. So you may need to move some defines in earlier
patches.

cheers,
jamal



