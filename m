From: Eyal perry <eyalpe@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 1/2] ethtool: Support for configurable RSS
 hash function
Date: Sun, 23 Nov 2014 12:13:54 +0200
Message-ID: <5471B362.6050706@dev.mellanox.co.il>
References: <1416493610-8966-1-git-send-email-amirv@mellanox.com>	<1416493610-8966-2-git-send-email-amirv@mellanox.com> <20141122.165407.641057904952001007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, eyalpe@mellanox.com,
	thomas.lendacky@amd.com, ariel.elior@qlogic.com,
	prashant@broadcom.com, mchan@broadcom.com, hariprasad@chelsio.com,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	linux-net-drivers@solarflare.com, sshah@solarflare.com,
	sbhatewara@vmware.com, pv-drivers@vmware.com
To: David Miller <davem@davemloft.net>, amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:53291 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbaKWKOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 05:14:03 -0500
Received: by mail-wi0-f173.google.com with SMTP id r20so3038158wiv.12
        for <netdev@vger.kernel.org>; Sun, 23 Nov 2014 02:14:01 -0800 (PST)
In-Reply-To: <20141122.165407.641057904952001007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2014 11:54 PM, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Thu, 20 Nov 2014 16:26:49 +0200
> 
>> +	/* We require at least one supported parameter to be changed and no
>> +	 * change in any of the unsupported parameters
>> +	 */
>> +	if ((!indir && !key) || hfunc != ETH_RSS_HASH_NO_CHANGE)
>> +		return -EOPNOTSUPP;
>> +
> 
> I know it will make more work for you, but all of these driver
> implementations of this hook should:
> 
> 1) Accept hfunc of whatever hash function the chip is using,
>    not just ETH_RSS_HASH_NO_CHANGE.
> 
> 2) Provide an accurate hfunc value in the ->get() call.
Ok, I'll do it for V2.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
