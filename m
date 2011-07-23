From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [ath9k-devel] [PATCH] ath9k: use pci_dev->subsystem_device
Date: Sat, 23 Jul 2011 03:53:32 -0400
Message-ID: <4E2A7DFC.3060401@gnu.org>
References: <201107221958.23408.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org, vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org, jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org
To: Sergei Shtylyov <sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201107221958.23408.sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/22/2011 11:58 AM, Sergei Shtylyov wrote:
> The driver reads PCI subsystem ID from the PCI configuration register while it's
> already stored by the PCI subsystem in the 'subsystem_device' field of 'struct
> pci_dev'...
>
> Signed-off-by: Sergei Shtylyov<sshtylyov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>

subsysid doesn't appear to be used anywhere.  It can be removed easily. 
  The patch will be sent separately.

-- 
Regards,
Pavel Roskin
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
