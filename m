From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: Add MOXA ART SoCs ethernet driver
Date: Thu, 01 Aug 2013 15:51:59 -0700 (PDT)
Message-ID: <20130801.155159.1229408467464868669.davem@davemloft.net>
References: <1375280401-5564-1-git-send-email-jonas.jensen@gmail.com>
 <1375349968-16059-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, linux-doc@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, arm@kernel.org,
 joe@perches.com, florian@openwrt.org, linux-arm-kernel@lists.infradead.org
To: jonas.jensen@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1375349968-16059-1-git-send-email-jonas.jensen@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Jonas Jensen <jonas.jensen@gmail.com>
Date: Thu,  1 Aug 2013 11:39:28 +0200

>     I have since found a problem occurring on high load. Please point out
>     anything the driver can do differently to eliminate it.
>     
>     The error only occurs during external ping, i.e. ping -s 50000 from
>     10.0.1.200 to hardware.

Looks like pure memory corruption.
