From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: wan-lmc: Improving source code formatting
Date: Sat, 20 Aug 2016 13:37:05 +0200
Message-ID: <88c39636-a0ba-b717-8c81-4b5574266abc@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, Amitoj Kaur Chawla <amitoj1606@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>,
        Florian Westphal <fw@strlen.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

The Coccinelle software pointed out that the function "lmc_ioctl"
is an update candidate according to the message "opportunity for memdup_user".
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/drivers/net/wan/lmc/lmc_main.c?id=6040e57658eee6eb1315a26119101ca832d1f854#n486

I guess that it would be nice to improve also this implementation.
But there are further constraints to consider. The script "checkpatch.pl"
can point information out like the following.

* ERROR: code indent should use tabs where possible

* WARNING: please, no spaces at the start of a line


The source files for this software module contain also some open issues
for the preferred source code formatting.

* How should these places be fixed so that they will match the current
  Linux coding style before additional adjustments can be safely tried?

* Would you like to suggest any advanced tools (besides "scripts/cleanfile")
  for a corresponding source code beautification?
  Which pretty-printing approaches are acceptable for Linux so far?

Regards,
Markus
