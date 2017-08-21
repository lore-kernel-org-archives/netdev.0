From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] qlogic: make device_attribute const
Date: Mon, 21 Aug 2017 10:25:06 -0700 (PDT)
Message-ID: <20170821.102506.1119648270525550825.davem@davemloft.net>
References: <1503315792-14837-1-git-send-email-bhumirks@gmail.com>
        <1503315792-14837-5-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
        jbacik@fb.com, jikos@kernel.org, benjamin.tissoires@redhat.com,
        manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, harish.patil@cavium.com,
        cascardo@holoscopio.com, don@syst.com.br, dvhart@infradead.org,
        andy@infradead.org, sre@kernel.org, linux-acpi@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-block@vger.kernel.org,
        nbd-general@lists.sourceforge.net, linux-input@vger.kernel.org,
        netdev@vger.kernel.org, platform-driver-x86@vger.kernel.org,
        linux-pm@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503315792-14837-5-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Mon, 21 Aug 2017 17:13:10 +0530

> Make these const as they are only passed as an argument to the
> function device_create_file and device_remove_file and the corresponding
> arguments are of type const.
> Done using Coccinelle
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.

But I would seriously suggest that when you have to cross subsystems
like this, just send the patches individually to the respective
maintainers rather than trying to make a "series" out of it.

Thanks.
