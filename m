From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] get rid of __OPTIMIZE__ requirement in net drivers
Date: Tue, 22 Jun 2004 15:52:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D88E02.1030701@pobox.com>
References: <20040622113052.1ef2cb7b@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040622113052.1ef2cb7b@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Several network drivers have checks that they are only built with -O.
> This breaks checking with sparse and other tools, and seems like a holdover from
> when drivers were built out of tree and the kernel build system was less stable.
> This patch gets rid of these.


Guess is 50% correct... holdover from people compiling the drivers 
out-of-tree using a single shell command (that runs gcc), found at the 
bottom of the driver.

No objection to the patch, though, just saying :)  I'll apply...

	Jeff
