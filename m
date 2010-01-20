From: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
Subject: Obsolete config in kernel (epic100) source (CONFIG_BIG_ENDIAN)
Date: Wed, 20 Jan 2010 12:50:23 +0100
Message-ID: <20100120115022.GA3580@faui49.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: siccegge@stud.informatik.uni-erlangen.de,
	Reinhard.Tartler@informatik.uni-erlangen.de
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	viro@ftp.linux.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753388Ab0ATLuG@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all!

	As part of the VAMOS[0] research project at the University of
Erlangen we're checking referential integrity between kernel KConfig
options and in-code Conditional blocks.

	The epic100 kernel dirver checks the variable
CONFIG_BIG_ENDIAN for turning on byteswapping. This Variable seems to
only have ever existed as a configuration option on the sh64 Platform
and is even there now renamed and no longer existent. SO I fear the
code won't behave as expected.

	I'm not attaching any patch as I'm not sure how to correctly
handle Endianess.

	Please keep me informed of this patch getting confirmed /
merged so we can keep track of it.

Regards

	Christoph Egger
