From: Pavel Andrianov <andrianov@ispras.ru>
Subject: A potential bug in drivers/net/ethernet/synopsys/dwc_eth_qos.ko
Date: Mon, 5 Sep 2016 11:26:46 +0300
Message-ID: <1403c768-7ed1-dc5c-38ae-ac91f876a175@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Vaishali Thakkar <vaishali.thakkar@oracle.com>,
        ldv-project@linuxtesting.org
To: Lars Persson <lars.persson@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

There is a potential bug in 
drivers/net/ethernet/synopsys/dwc_eth_qos.ko. In dwceqos_probe there is 
a registration of net device (line 2879). After that initialization of 
common resources is continued (lines 2918, 2924, 2941), but at the 
moment handlers from net device may be already executed.

Should the registration of net device be at the end of dwceqos_probe?

-- 
Pavel Andrianov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: andrianov@ispras.ru
