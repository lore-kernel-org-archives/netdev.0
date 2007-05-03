From: Mark Brown <broonie@sirena.org.uk>
Subject: [PATCH 0/2] natsemi: Improve DspCfg workaround
Date: Thu, 03 May 2007 10:36:44 +0100
Message-ID: <20070503093435.7800.38591.stgit@mercator.sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: =?utf-8?b?UmFmYcWC?= Bilski <rafalbilski@interia.pl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tim Hockin <thockin@hockin.org>, Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1031059AbXECJh6@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The natsemi driver contains a workaround for broken hardware which can
on some boards cause more problems than it solves.  The following patch
series improves this by making the diagnostic more obvious and allowing
users to disable the workaround if it causes them problems.

-- 
"You grabbed my hand and we fell into it, like a daydream - or a fever."
