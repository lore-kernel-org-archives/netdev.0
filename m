From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Fri, 14 Sep 2007 17:14:53 -0400
Message-ID: <46EAF9CD.1090808@garzik.org>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org> <20070914211210.GB12444@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38109 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756635AbXINVO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 17:14:56 -0400
In-Reply-To: <20070914211210.GB12444@fieldses.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

J. Bruce Fields wrote:
> On Fri, Sep 14, 2007 at 03:07:46PM -0400, Jeff Garzik wrote:
>> I've been waiting for years for a smart person to come along and write a 
>> POSIX-only distributed filesystem.

> What exactly do you mean by "POSIX-only"?

Don't bother supporting attributes, file modes, and other details not 
supported by POSIX.  The prime example being NFSv4, which is larded down 
with Windows features.

NFSv4.1 adds to the fun, by throwing interoperability completely out the 
window.

	Jeff



