From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Makefile: Document ability to make file.lst and file.S
Date: Wed, 13 Jan 2010 09:31:44 -0800
Message-ID: <1263403904.8011.83.camel@Joe-Laptop.home>
References: <4B49D001.4000302@gmail.com> <4B4DA4F4.6060007@gmail.com>
	 <20100113115617.GA24818@basil.fritz.box> <4B4DE887.6030602@gmail.com>
	 <20100113155323.GB24818@basil.fritz.box>
	 <1263400835.8011.73.camel@Joe-Laptop.home>
	 <20100113171411.GC24818@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Marek <mmarek@suse.cz>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kbuild@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20100113171411.GC24818@basil.fritz.box>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-01-13 at 18:14 +0100, Andi Kleen wrote:
> On Wed, Jan 13, 2010 at 08:40:35AM -0800, Joe Perches wrote:
> > On Wed, 2010-01-13 at 16:53 +0100, Andi Kleen wrote:
> > > On Wed, Jan 13, 2010 at 10:36:39AM -0500, William Allen Simpson wrote:
> > > > What make command would you suggest to get the interleaved asm?
> > > make path/to/file.lst
> > > (or .S -- you might need uptodate binutils if the lst listing is messed up)
> > I didn't know that was possible.
> The trap is that it doesn't work well on most systems with too 
> old binutils (unless the gcc is really ancient)

Then that might as well go into the help.

Signed-off-by: Joe Perches <joe@perches.com>
---
diff --git a/Makefile b/Makefile
index 9f64552..484cff4 100644
--- a/Makefile
+++ b/Makefile
@@ -1248,7 +1248,9 @@ help:
 	@echo  '  firmware_install- Install all firmware to INSTALL_FW_PATH'
 	@echo  '                    (default: $$(INSTALL_MOD_PATH)/lib/firmware)'
 	@echo  '  dir/            - Build all files in dir and below'
-	@echo  '  dir/file.[ois]  - Build specified target only'
+	@echo  '  dir/file.[oisS] - Build specified target only'
+	@echo  '  dir/file.lst    - Build specified mixed source/assembly target only'
+	@echo  '                    (requires a recent binutils and recent build (System.map))'
 	@echo  '  dir/file.ko     - Build module including final link'
 	@echo  '  modules_prepare - Set up for building external modules'
 	@echo  '  tags/TAGS	  - Generate tags file for editors'


