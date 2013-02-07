From: Freddy <freddy@asix.com.tw>
Subject: Re: [PATCH, resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0
 to gigabit ethernet adapter driver
Date: Thu, 07 Feb 2013 14:50:09 +0800
Message-ID: <51134EA1.7000403@asix.com.tw>
References: <1360211794-4737-1-git-send-email-freddy@asix.com.tw> <20130206214603.72524632@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130206214603.72524632@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/2013 01:46 PM, Stephen Hemminger wrote:
> On Thu,  7 Feb 2013 12:36:34 +0800
> Freddy Xin <freddy@asix.com.tw> wrote:
>
>> +static struct ethtool_ops ax88179_ethtool_ops = {
>> +	.get_link		= ethtool_op_get_link,
>> +	.get_msglevel		= usbnet_get_msglevel,
>> +	.set_msglevel		= usbnet_set_msglevel,
>> +	.get_wol		= ax88179_get_wol,
>> +	.set_wol		= ax88179_set_wol,
>> +	.get_eeprom_len		= ax88179_get_eeprom_len,
>> +	.get_eeprom		= ax88179_get_eeprom,
>> +	.get_settings		= ax88179_get_settings,
>> +	.set_settings		= ax88179_set_settings,
>> +	.nway_reset		= usbnet_nway_reset,
>> +};
>> +
> ethtool_ops should always be const
>
Thank you, Stephen. I will fix these errors.
