From: Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: add calxeda xgmac ethernet driver
Date: Fri, 04 Nov 2011 15:52:01 -0500
Message-ID: <4EB45071.8000406@gmail.com>
References: <1319684206-473-1-git-send-email-robherring2@gmail.com>
 <CACxGe6sAFUwQc5Nk=gGLC+si-_C32AWu=E14vBkSm7YCFhazFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <CACxGe6sAFUwQc5Nk=gGLC+si-_C32AWu=E14vBkSm7YCFhazFg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Grant,

On 11/04/2011 11:57 AM, Grant Likely wrote:
> On Wed, Oct 26, 2011 at 10:56 PM, Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> From: Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
>>
>> Add support for the XGMAC 10Gb ethernet device in the Calxeda Highbank
>> SOC.
>>
>> Signed-off-by: Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
> 
> Sinker question: is this a driver for an entirely new GMAC device
> (designed from scratch) or is it based on an existing IP block?
> 

Of course I'd rather use a existing driver. It is a new IP block.

>> +/**
>> + * xgmac_init - Entry point for the driver
>> + * Description: This function is the entry point for the driver.
>> + */
>> +static int __init xgmac_init(void)
>> +{
>> +       return platform_driver_register(&xgmac_driver);
>> +}
>> +module_init(xgmac_init);
>> +
>> +/**
>> + * xgmac_cleanup_module - Cleanup routine for the driver
>> + * Description: This function is the cleanup routine for the driver.
>> + */
>> +static void __exit xgmac_exit(void)
>> +{
>> +       platform_driver_unregister(&xgmac_driver);
>> +}
>> +module_exit(xgmac_exit);
> 
> You can drop some boilerplate with module_platform_driver() now.

Okay.

Rob
