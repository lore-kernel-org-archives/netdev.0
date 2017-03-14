From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] usbnet: smsc95xx: Reduce logging noise
Date: Mon, 13 Mar 2017 19:13:11 -0700
Message-ID: <59ee1010-7135-1225-84b3-a402904a7f7e@roeck-us.net>
References: <1489196721-12888-1-git-send-email-linux@roeck-us.net>
 <20170313.153236.1183838776173721070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170313.153236.1183838776173721070.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 03:32 PM, David Miller wrote:
> From: Guenter Roeck <linux@roeck-us.net>
> Date: Fri, 10 Mar 2017 17:45:21 -0800
>
>> An insert/remove stress test generated the following log message sequence.
> ...
>> Use netdev_dbg() instead of netdev_warn() for the repeating messages
>> to reduce logging noise.
>>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>
> The problem I have with changes like this is that outside of your
> stress test situation these messages are extremely useful but will
> now be hidden making diagnosis of problems more difficult.
>

In general I agree, but in this case the calling code also generates
another set of error messages, which I considered a bit excessive.

No problem, though, we can live with the noise.

Guenter
