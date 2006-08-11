From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH 3/6] ehea: queue management
Date: Fri, 11 Aug 2006 15:04:11 +0200
Message-ID: <44DC804B.70609@de.ibm.com>
References: <44D99F38.8010306@de.ibm.com> <20060811000540.200CE67B6B@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Klein <tklein@de.ibm.com>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751119AbWHKNmm@vger.kernel.org>
To: Michael Neuling <mikey@neuling.org>
In-Reply-To: <20060811000540.200CE67B6B@ozlabs.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>
>> +#define EHEA_EQE_SM_MECH_NUMBER  EHEA_BMASK_IBM(48, 55)
>> +#define EHEA_EQE_SM_PORT_NUMBER  EHEA_BMASK_IBM(56, 63)
>> +
>> +struct ehea_eqe {
>> +	u64 entry;
>> +};
> 
> ehea_ege.. what is that and why a struct if only 1 item?  Comments
> please.  
> 

There are send / receive queue elements (ehea_swqe, ehea_rwqe),
completion queue elements (ehea_cqe) and event queue elements (ehea_eqe).
We introduced struct ehea_eqe to get a consistent description for all
queue elements.

Jan-Bernd
