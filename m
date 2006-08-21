From: Thomas Klein <osstklei@de.ibm.com>
Subject: Re: [2.6.19 PATCH 4/7] ehea: ethtool interface
Date: Mon, 21 Aug 2006 11:53:31 +0200
Message-ID: <44E9829B.7010503@de.ibm.com>
References: <200608181333.23031.ossthema@de.ibm.com>	<20060818140506.GC5201@martell.zuzino.mipt.ru>	<44E5DFA6.7040707@de.ibm.com>
	<20060818104547.5ad1352f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>, linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>, Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060818104547.5ad1352f@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 18 Aug 2006 17:41:26 +0200
> Thomas Klein <osstklei@de.ibm.com> wrote:
> 
>> Hi Alexey,
>>
>> first of all thanks a lot for the extensive review.
>>
>>
>> Alexey Dobriyan wrote:
>>>> +	u64 hret = H_HARDWARE;
>>> Useless assignment here and everywhere.
>>>
>> Initializing returncodes to errorstate is a cheap way to prevent
>> accidentally returning (uninitalized) success returncodes which
>> can lead to catastrophic misbehaviour.
> 
> That is old thinking. Current compilers do live/dead analysis
> and tell you about this at compile time which is better than relying
> on default behavior at runtime.

Understood. I reworked the returncode handling and removed the
unnecessary initializations.

Thanks for pointing this out.

Thomas
