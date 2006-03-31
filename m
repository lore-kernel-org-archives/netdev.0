From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH]: e1000: prevent statistics from getting garbled during
 reset.
Date: Fri, 31 Mar 2006 09:36:30 -0800
Message-ID: <442D689E.9080209@hp.com>
References: <20060330213928.GQ2172@austin.ibm.com>	<20060331000208.GS2172@austin.ibm.com>	<442C8069.507@wolfmountaingroup.com>	<20060331003506.GU2172@austin.ibm.com>	<442CACC0.1060308@wolfmountaingroup.com> <20060331170319.GV2172@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linuxppc-dev@ozlabs.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932138AbWCaRgc@vger.kernel.org>
In-Reply-To: <20060331170319.GV2172@austin.ibm.com>
To: unlisted-recipients:; (no To-header on input)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 2) What's wrong with taking deltas? Typical through-put performance
> measurement is done by pre-loading the pipes (i.e. running for
> a few minutes wihtout measuring, then starting the measurement).
> I'd think that snapshotting the numbers would be easier, and is 
> trivially doable in user-space. I guess I don't understand why 
> you need a new kernel featre to imlement this.

ftp://ftp.cup.hp.com/dist/networking/tools/beforeafter.tar.gz

Not my code, I've used it with success against ethtool -S output.

rick jones
