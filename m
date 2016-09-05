From: Lars Persson <lars.persson@axis.com>
Subject: Re: A potential bug in drivers/net/ethernet/synopsys/dwc_eth_qos.ko
Date: Mon, 5 Sep 2016 13:45:28 +0200
Message-ID: <e72ce0af-c35d-bbf9-e30f-f40f3b9053f0@axis.com>
References: <1403c768-7ed1-dc5c-38ae-ac91f876a175@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Vaishali Thakkar <vaishali.thakkar@oracle.com>,
        <ldv-project@linuxtesting.org>
To: Pavel Andrianov <andrianov@ispras.ru>,
        Lars Persson <larper@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403c768-7ed1-dc5c-38ae-ac91f876a175@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel,

Thanks for the notification. I agree that we should register the device 
after all initialization has completed. A patch will be sent shortly.

BR,
  Lars


On 09/05/2016 10:26 AM, Pavel Andrianov wrote:
> Hi!
>
> There is a potential bug in
> drivers/net/ethernet/synopsys/dwc_eth_qos.ko. In dwceqos_probe there is
> a registration of net device (line 2879). After that initialization of
> common resources is continued (lines 2918, 2924, 2941), but at the
> moment handlers from net device may be already executed.
>
> Should the registration of net device be at the end of dwceqos_probe?
>
