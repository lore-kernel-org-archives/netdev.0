From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: Add firmware for r8723au
Date: Wed, 04 Jun 2014 11:11:44 -0500
Message-ID: <538F4540.9080002@lwfinger.net>
References: <1388709729-28496-1-git-send-email-Larry.Finger@lwfinger.net>	 <1390174519.3651.3.camel@deadeye.wl.decadent.org.uk> <1401833651.2412.35.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>, dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1401833651.2412.35.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/03/2014 05:14 PM, Ben Hutchings wrote:
> On Sun, 2014-01-19 at 23:35 +0000, Ben Hutchings wrote:
>> On Thu, 2014-01-02 at 18:42 -0600, Larry Finger wrote:
>>> This firmware is for a driver that will soon be submitted to the kernel.
>>> It occurs as data statements in Realtek driver rtl8723A_WiFi_linux_v4.1.3_6044.20121224.
>>>
>>> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
>>> ---
>>>   WHENCE                         |  13 +++++++++++++
>>>   rtlwifi/rtl8723aufw_A.bin      | Bin 0 -> 22172 bytes
>>>   rtlwifi/rtl8723aufw_B.bin      | Bin 0 -> 24118 bytes
>>>   rtlwifi/rtl8723aufw_B_NoBT.bin | Bin 0 -> 19200 bytes
>>>   4 files changed, 13 insertions(+)
>>>   create mode 100644 rtlwifi/rtl8723aufw_A.bin
>>>   create mode 100644 rtlwifi/rtl8723aufw_B.bin
>>>   create mode 100644 rtlwifi/rtl8723aufw_B_NoBT.bin
>> [...]
>>
>> Applied, thanks.
>
> I just noticed that the driver in Linux 3.15 seems to ask for
> rtlwifi/rtl8723aufw.bin and not rtlwifi/rtl8723aufw_A.bin.  You'll need
> to change the filename on one side or the other.

Jes,

As Ben points out, I messed up the firmware names, and one of them needs to be 
changed. Keeping the name "rtlwifi/rtl8723aufw_A.bin" would retain a certain 
amount of symmetry, but is may be easier to retain "rtlwifi/rtl8723aufw.bin" in 
the code. A third option would be to try for one of the names and fall back to 
the other if it fails. What do you think?

In any case, we need additional MODULE_FIRMWARE macros for the other two 
firmware files.

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
