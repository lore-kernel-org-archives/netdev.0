From: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
Subject: Re: [lm-sensors] [PATCH 01/34] System Firmware Interface
Date: Mon, 25 Jul 2011 21:03:21 +0200
Message-ID: <20110725210321.1e2f252e@endymion.delvare>
References: <1310994528-26276-1-git-send-email-prarit@redhat.com>
	<1310994528-26276-2-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	device-drivers-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org, abelay-3s7WtUTddSA@public.gmane.org,
	eric.piel-VkQ1JFuSMpfAbQlEx87xDw@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	lm-sensors-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org, linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, dz-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org,
	openipmi-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	evel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rpurdie-Fm38FmjxZ/leoWH0uzbU5w@public.gmane.org,
	linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Prarit Bhargava <prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1310994528-26276-2-git-send-email-prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 18 Jul 2011 09:08:15 -0400, Prarit Bhargava wrote:
> This patch introduces a general System Firmware interface to the kernel, called
> sysfw.
> 
> Inlcluded in this interface is the ability to search a standard set of fields,
> sysfw_lookup().  The fields are currently based upon the x86 and ia64 SMBIOS
> fields but exapandable to fields that other arches may introduce.  Also
> included is  the ability to search and match against those fields, and run
> a callback function against the matches, sysfw_callback().
> 
> Modify module code to use sysfw instead of old DMI interface.

This is a HUGE patch set. You'd need to have a good reason for such a
big and intrusive change, yet I see no such reason explained. I
understand that we _can_ abstract system information interfaces, but
just because we can doesn't mean we have to. I would at least wait for
a second DMI-like interface to be widely implemented and support before
any attempt to abstract, otherwise your design is bound to be missing
the target. And even then, you'd still need to convince me that there
is a need for a unified interface to access both backends at once. I
would guess that you know what backend is present on a system when you
try to identify it.

At this point, I see the work needed to review your patches, the risk
of regressions due to the large size of the patch set, but I don't see
any immediate benefit. Thus I am not going to look into it at all,
sorry.

-- 
Jean Delvare
