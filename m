From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/3] 2.6.5-netdev2 - r8169 update
Date: Tue, 13 Apr 2004 14:27:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <407C3111.4040606@pobox.com>
References: <20040405235545.A20805@electric-eye.fr.zoreil.com> <20040407231332.A25021@electric-eye.fr.zoreil.com> <20040407231444.A25867@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Srihari Vijayaraghavan <harisri@telstra.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040407231444.A25867@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My apologies, these three patches applied successfully to 2.6.x:

1) Missing 'static' qualifier for functions.
2) The irq handler must not return 1 when the status register is null
during the firt iteration.
3) mod_timer() expects an absolute time, not a relative offset.

Also, future requests:

a) please include a useful Subject line (mentioned in previous email)
b) please -exclude- your diffstat output
