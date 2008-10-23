From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: linux/vmxnet
Date: Wed, 22 Oct 2008 18:25:36 -0700
Message-ID: <c0a09e5c0810221825x366dd639h651286ff81f934db@mail.gmail.com>
References: <592182.29492.qm@web59608.mail.ac4.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael Chang" <michaelcn_chang@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:28326 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022AbYJWBZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 21:25:37 -0400
Received: by wf-out-1314.google.com with SMTP id 27so88893wfd.4
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 18:25:37 -0700 (PDT)
In-Reply-To: <592182.29492.qm@web59608.mail.ac4.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2008 at 2:57 PM, Michael Chang
<michaelcn_chang@yahoo.com> wrote:
> 1)Is vmxnet opensource. Where can I find its source.

The vmxnet driver is labeled Vmware Confidential. I got its source by
looking in the VmwareTools tgz. It's not open source so basically game
over. Why not try KVM or Xen?

> 2)Once vmxnet is in linux kernel, what changes we need to implement in
> physical ethernet driver on host to make it work with vmxnet OR "any
> other virtualization".

VMWare, Xen, and KVM all have different interfaces for paravirtualized
net and block drivers.

> 3) Any other info will be appreciated.

Google "virtio".

Regards -- Andy
