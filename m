From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-sysfs: Report link speed as signed integer
Date: Mon, 02 Jun 2014 11:10:50 -0700 (PDT)
Message-ID: <20140602.111050.54996809312556969.davem@davemloft.net>
References: <06d53256e3bf2d0deedb16249082200500da3ee6.1401718809.git.mprivozn@redhat.com>
	<20140602143557.GA2925@minipsycho.orion>
	<20140602150150.GF6295@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, mprivozn@redhat.com, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: vfalico@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140602150150.GF6295@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon, 2 Jun 2014 17:01:50 +0200

> I wonder, though, if we should document it or just output "Unknown"
> instead of -1.

All of this discussion means that we can't change the format string
without potentially breaking something out there interpreting the -1
value, however it gets output now.

I think we just have to leave things as-is and document them in the
sysfs ABI docs.

I'm not applying this patch.
