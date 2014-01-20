From: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Subject: Re: ping [PATCH v3] WAN: Adding support for Lantiq PEF2256 E1 chipset
 (FALC56)
Date: Sun, 19 Jan 2014 18:50:18 -0600
Message-ID: <52DC72CA.3090403@landley.net>
References: <20140119180732.A1D99432AF@localhost.localdomain> <1390160095.2290.9.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marc.balemboy-GgN8y9CXRhA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Christophe Leroy <christophe.leroy-GgN8y9CXRhA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1390160095.2290.9.camel@joe-AO722>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/19/14 13:34, Joe Perches wrote:
> On Sun, 2014-01-19 at 19:07 +0100, Christophe Leroy wrote:
>> Pinging this watch as we got no feedback since 22 Nov, although we have taken
>> into account reviews from v1 and v2.
>>
>> The patch adds WAN support for Lantiq FALC56 - PEF2256 E1 Chipset.
...
>> +static ssize_t fs_attr_Tx_TS_store(struct device *dev,
>> +			struct device_attribute *attr,  const char *buf,
>> +			size_t count)
>> +{
>> +	struct net_device *ndev = dev_get_drvdata(dev);
>> +	struct pef2256_dev_priv *priv = dev_to_hdlc(ndev)->priv;
>> +	unsigned long value;
>> +	int ret = kstrtoul(buf, 16, (long int *)&value);
>
> unportable cast

How is that not portable? It's long == pointer on Linux, which supports 
LP64 on all targets. (As do BSD, MacOSX, android, and iOS.)

   http://www.unix.org/whitepapers/64bit.html
   http://www.unix.org/version2/whatsnew/lp64_wp.html

Do you mean it's not portable to Windows?

   http://blogs.msdn.com/oldnewthing/archive/2005/01/31/363790.aspx

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
