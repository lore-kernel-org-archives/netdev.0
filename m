From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [2.6 patch] kill include/linux/eeprom.h
Date: Wed, 20 Apr 2005 10:42:39 -0400
Message-ID: <20050420144239.GA14757@kvack.org>
References: <20050419012935.GQ5489@stusta.de> <20050419135648.GC7315@kvack.org> <20050419235646.GY5489@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20050419235646.GY5489@stusta.de>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 20, 2005 at 01:56:46AM +0200, Adrian Bunk wrote:
> Where does my patch do this?
> Only the one actually used function setup_ee_mem_bitbanger is moved to
> ns83820.c .

Which is dead code if you have removed the other users of the data 
structure it initialized.  Please try to understand the intent of the 
code being cleaned up instead of just blindly deleting things, and be 
thorough.

		-ben
