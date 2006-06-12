From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH 3/5] ehea: queue management
Date: Mon, 12 Jun 2006 09:14:26 +0200
Message-ID: <448D1452.503@de.ibm.com>
References: <4487F421.2050001@de.ibm.com> <1149878470.28483.6.camel@sinatra.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Marcus Eder <MEDER@de.ibm.com>,
	Christoph Raisch <RAISCH@de.ibm.com>, themann@de.ibm.com,
	tklein@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:31763 "EHLO
	mtagate2.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1750830AbWFLHno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 03:43:44 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k5C7hfbY080690
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 12 Jun 2006 07:43:43 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5C7irxL126178
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 12 Jun 2006 08:44:54 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5C7hdc4009009
	for <netdev@vger.kernel.org>; Mon, 12 Jun 2006 08:43:39 +0100
To: John Rose <johnrose@austin.ibm.com>
In-Reply-To: <1149878470.28483.6.camel@sinatra.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Rose wrote:
>> +#define EHEA_MEM_START 0xc000000000000000
> 
> You probably don't want to hardcode this.  Maybe KERNELBASE from page.h?

Yes, we want to use KERNELBASE

> 
>> +
>> +int ehea_reg_mr_adapter(struct ehea_adapter *adapter)
>> +{
>> +	}
> 
> This creates DMA mappings for the entirety of kernel memory, right?  Has
> this been run by the ppc64 folks for possible impacts?

Yes, that is correct. We have tested it on our ppc64 without running into any
problems. There should be no impacts on other kernel parts, but we haven't
talked to the ppc64 folks yet.

Jan-Bernd
