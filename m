From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix possible deadlock in ip6_fl_purge / ip6_fl_gc
Date: Thu, 12 Feb 2015 07:13:45 -0800 (PST)
Message-ID: <20150212.071345.471727008346984271.davem@davemloft.net>
References: <a26e3a5267c2a8816655018c5d46adcf52e71948.1423659369.git.jstancek@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jstancek@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a26e3a5267c2a8816655018c5d46adcf52e71948.1423659369.git.jstancek@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Stancek <jstancek@redhat.com>
Date: Wed, 11 Feb 2015 14:06:23 +0100

> Use spin_lock_bh in ip6_fl_purge() to prevent following potentially
> deadlock scenario between ip6_fl_purge() and ip6_fl_gc() timer.
...
> Signed-off-by: Jan Stancek <jstancek@redhat.com>

Applied.
