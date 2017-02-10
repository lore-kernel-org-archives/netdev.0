From: Marty Plummer <netz.kernel@gmail.com>
Subject: net: hix5hd2_gmac uninitialized net_device
Date: Fri, 10 Feb 2017 01:45:45 -0600
Message-ID: <20170210074544.eoabpjf522pmwoui@tha-monstah.mydomain>
References: <20170210074118.vchxsn7fag6tlsmg@tha-monstah.mydomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:36731 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751922AbdBJHqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 02:46:35 -0500
Received: by mail-ot0-f194.google.com with SMTP id 36so3055233otx.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 23:45:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170210074118.vchxsn7fag6tlsmg@tha-monstah.mydomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 01:41:18AM -0600, Marty Plummer wrote:
> Greetings.
> 
> I think I may have found a bug with the hix5hd2_gmac driver; unless I'm
> missing something, it appears that somehow the net_device struct is not
> being initialized properly in the hix5hd2_dev_probe function.
> 
> Having set up my devicetree properly (I hope, still new to this), I first
> recieved an error when inserting the module:
> "(unnamed net_device) (uninitialized): No irq resource"
> while I very clearly have the interrupts property defined within this node.
> 
> Removing the phy-handle node for testing purposes, I get a similar message:
> "(unnamed net_device) (uninitialized): not find phy-handle"
> 
> So, it seams to my (admittedly inexperienced) mind that the ndev pointer is
> not being initialized properly, or that the error checking at line 1111
> is not functioning properly either, for it to have gotten so far along
> into the function, only to fail at the attempt to access the ndev pointer.
> 
> If you require more information from me, please let me know.
> 
> Marty

Sorry, forgot the subject. Still getting the hang of mutt.
