From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 0/12] qlcnic: patches for new adapter - Qlogic 83XX CNA
Date: Fri, 31 Aug 2012 02:28:49 -0400
Message-ID: <1346394541-3486-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:14547 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751403Ab2HaGpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 02:45:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

>From: David Miller [mailto:davem@davemloft.net]

>Firstly, I'm not going to let you create arbitrary new sysfs
>and debugfs crap for facilities that are already supported by
>the kernel via other interfaces.

>For example, providing a facility to read and write the PCI BARs
>is completely pointless.  Use the PCI config space access APIs for
>this if you want to do this from userspace.

>The patches are also much more verbose than they need to be.
>When you move an operation to the new hwops, keep the existing function
>name but make it an inline function that invokes the hwop.

>That way you won't need hundreds of lines in your patch that look like this:

>-	qlcnic_clear_lb_mode(adapter);
>+	ahw->hw_ops->clear_loopback(adapter, mode);

>Instead you'd have:

>static inline void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter,
>							u8 mode) {
>	struct qlcnic_hardware_context *ahw = &adapter->ahw;

>	ahw->hw_ops->clear_loopback(adapter, mode); }

I have made the changes as you suggested above.
Please apply the updated pacth series to net-next.

Thanks,
Sony
