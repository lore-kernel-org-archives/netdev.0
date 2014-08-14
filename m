From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: network interfaces called "all", "default" or "config"
Date: Thu, 14 Aug 2014 11:28:58 -0700
Message-ID: <20140814112858.35a0cc88@haswell.linuxnetplumber.net>
References: <20140723113314.GA7798@chaz.gmail.com>
	<53CFCD26.1020409@infradead.org>
	<CACsCDOP8DOnB0zZtT_WLhiBXjxXh1aH1eGF9_h0dRN1i9YDU-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephane Chazelas <stephane.chazelas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:55847 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978AbaHNS3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 14:29:03 -0400
Received: by mail-pd0-f175.google.com with SMTP id r10so2007860pdi.20
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 11:29:02 -0700 (PDT)
In-Reply-To: <CACsCDOP8DOnB0zZtT_WLhiBXjxXh1aH1eGF9_h0dRN1i9YDU-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Aug 2014 10:41:39 +0100
Stephane Chazelas <stephane.chazelas@gmail.com> wrote:

> $ ip link add link eth0 eth0:123 type vlan id 123
> $ ip link del link eth0 eth0:123
> RTNETLINK answers: Operation not supported

eth0:123 is one of the old style interface names.
Kernel and iproute treat these specially.
Don't use them. They exist only for compatibility with the
dark ages.

You should use period (ie eth0.123) for VLAN's
