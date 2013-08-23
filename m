From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH v4 1/5] net: ethernet: cpsw: switch to devres allocations
Date: Fri, 23 Aug 2013 20:34:17 +0200
Message-ID: <5217AB29.9020209@gmail.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com>
 <1377267365-24057-2-git-send-email-zonque@gmail.com>
 <5217A5AE.6090704@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, d-gerlach@ti.com, netdev@vger.kernel.org,
 nsekhar@ti.com, vaibhav.bedia@ti.com, devicetree@vger.kernel.org,
 bcousson@baylibre.com, ujhelyi.m@gmail.com, linux-omap@vger.kernel.org,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <5217A5AE.6090704@cogentembedded.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 23.08.2013 20:10, Sergei Shtylyov wrote:
> On 08/23/2013 06:16 PM, Daniel Mack wrote:

>>   	priv->coal_intvl = 0;
>>   	priv->bus_freq_mhz = clk_get_rate(priv->clk) / 1000000;
>>
>> -	priv->cpsw_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>> -	if (!priv->cpsw_res) {
>> +	ss_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>> +	if (!ss_res) {
> 
>     You don't need to check the result of platform_get_resource() if you call
> devm_ioremap_resource() right afterwards -- it will check resource ptr for 
> NULL the first thing. :-)

Thanks! Will address that in v5.


Daniel
