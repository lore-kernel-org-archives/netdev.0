From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: SoCFPGA ethernet broken
Date: Thu, 15 Oct 2015 14:30:15 -0700
Message-ID: <56201AE7.2020103@gmail.com>
References: <561FF9E2.30102@opensource.altera.com> <56200687.9040903@gmail.com> <562005AD.8020903@opensource.altera.com> <56200BD7.8020505@gmail.com> <56200E15.9080603@caviumnetworks.com> <56201158.8040806@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, david.daney@cavium.com,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dinh Nguyen <dinguyen@opensource.altera.com>,
	David Daney <ddaney@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56201158.8040806@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/10/15 13:49, Dinh Nguyen wrote:
>>
>> Does this text change with and without the 8b63ec1837fa patch?
> 
> No, this text does not change with/without the 8b63ec1837fa patch.

Could you instrument mdiobus_scan(), get_phy_device() and
phy_device_create/register to see if the parent is NULL, non-NULL?

So far, I cannot see what is wrong with David's changes, quite the
contrary, and if there was something wrong with the PHY device creation,
it should not get you that far.

You have not answered my previous question though, do you have PHY
fixups registered for that ID?
-- 
Florian
