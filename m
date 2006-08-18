From: Thomas Klein <osstklei@de.ibm.com>
Subject: Re: [2.6.19 PATCH 3/7] ehea: queue management
Date: Fri, 18 Aug 2006 15:25:11 +0200
Message-ID: <44E5BFB7.4000400@de.ibm.com>
References: <200608181331.19501.ossthema@de.ibm.com> <1155903451.4494.168.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751384AbWHRNZQ@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1155903451.4494.168.camel@laptopd505.fenrus.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
>> +	queue->queue_length = nr_of_pages * pagesize;
>> +	queue->queue_pages = vmalloc(nr_of_pages * sizeof(void *));
> 
> 
> wow... is this really so large that it warrants a vmalloc()???

Agreed: Replaced with kmalloc()

Regards
Thomas
