From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [PATCH 1/1] More ethtool support for sis900
Date: Sat, 5 Mar 2005 21:53:37 +0100
Message-ID: <02a49476862ae18433e5b80aafa616fd@libero.it>
References: <20050305134011.23638.68926@localhost.localdomain> <4229FA32.4000401@pobox.com>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
In-Reply-To: <4229FA32.4000401@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 05/mar/05, at 19:28, Jeff Garzik wrote:
>> +static int sis900_set_settings(struct net_device *net_dev,
>> +				struct ethtool_cmd *cmd)
>> +{
>> +	struct sis900_private *sis_priv = net_dev->priv;
>> +	return mii_ethtool_sset(&sis_priv->mii_info, cmd);
>> +}
>> +
>> +static int sis900_nway_reset(struct net_device *net_dev)
>> +{
>> +	struct sis900_private *sis_priv = net_dev->priv;
>> +	return mii_nway_restart(&sis_priv->mii_info);
>> +}
>
> I should think you want locking for these, as is present in other 
> drivers...
I saw the locking, but I couldn't come up with a reason for it. Is it 
needed because of kernel wide preemption ?
I don't like copying blindly and the documentation for the mii 
interface is a bit lacking...

Will follow up with a new patch in a few minutes...

--
Daniele Venzano
http://www.brownhat.org
