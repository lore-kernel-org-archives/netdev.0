From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/2] Revert "ipv6: constify inet6_protocol structures"
Date: Tue,  1 Aug 2017 18:27:27 +0200
Message-ID: <1501604849-19443-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, bhumirks@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

inet6_add_protocol and inet6_del_protocol include casts that remove the
effect of the const annotation on their parameter, leading to possible
runtime crashes.
