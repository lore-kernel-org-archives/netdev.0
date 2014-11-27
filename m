From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: r8188eu: Add new device ID for DLink GO-USB-N150
Date: Thu, 27 Nov 2014 10:47:59 -0600
Message-ID: <547755BF.2080207@lwfinger.net>
References: <1417104621-9504-1-git-send-email-Larry.Finger@lwfinger.net>
 <20141127162854.GB1404@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20141127162854.GB1404@kroah.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 11/27/2014 10:28 AM, Greg KH wrote:
> On Thu, Nov 27, 2014 at 10:10:21AM -0600, Larry Finger wrote:
>> The DLink GO-USB-N150 with revision B1 uses this driver.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---
>>   drivers/staging/rtl8188eu/os_dep/usb_intf.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
>> index 65a257f..d3cbcc4 100644
>> --- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
>> +++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
>> @@ -47,6 +47,7 @@ static struct usb_device_id rtw_usb_id_tbl[] = {
>>   	{USB_DEVICE(0x07b8, 0x8179)}, /* Abocom - Abocom */
>>   	{USB_DEVICE(0x2001, 0x330F)}, /* DLink DWA-125 REV D1 */
>>   	{USB_DEVICE(0x2001, 0x3310)}, /* Dlink DWA-123 REV D1 */
>> +	{USB_DEVICE(0x2001, 0x3311)}, /* DLink GO-USB-N150 REV B1 */
>>   	{USB_DEVICE(0x0df6, 0x0076)}, /* Sitecom N150 v2 */
>>   	{}	/* Terminating entry */
>>   };
>> --
>> 2.1.2
>
> Should this also go to stable kernels?

Yes, it should. Sorry for missing that Cc.

Larry
