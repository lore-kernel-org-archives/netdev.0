From: Cong Wang <cwang@twopensource.com>
Subject: Re: list of all network namespaces
Date: Thu, 17 Sep 2015 11:11:36 -0700
Message-ID: <CAHA+R7OQ2RrqfTyZODm2LJFaX2X5jp-ibnM8cRcUsB8Bju_7EA@mail.gmail.com>
References: <CAOxq_8Noj5oxPY5BEsWL6u4h_AD+oXYS+JCRGES_gmMQKd0rOQ@mail.gmail.com>
	<55FA0F4A.3010105@hp.com>
	<9B0331B6EBBD0E4684FBFAEDA55776F919440808@HASMSX110.ger.corp.intel.com>
	<CAOxq_8OTR2neJhDU4BOubWcc7Qd=j9T3jg4ESv-ojXqj+xxYxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Rosen, Rami" <rami.rosen@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:36758 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbbIQSLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 14:11:37 -0400
Received: by ykdt18 with SMTP id t18so24771442ykd.3
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 11:11:36 -0700 (PDT)
In-Reply-To: <CAOxq_8OTR2neJhDU4BOubWcc7Qd=j9T3jg4ESv-ojXqj+xxYxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 10:39 AM, Ani Sinha <ani@arista.com> wrote:
> On Thu, Sep 17, 2015 at 2:51 AM, Rosen, Rami <rami.rosen@intel.com> wrote:
>
>> Network namespaces which were created by other ways (like userspace applications
>> using the clone() system call) will *not* be reflected by neither of them.
>
> Will there be any interest if I cook up a kernel patch that lists all
> network namespaces through /proc?

How do you list them since they don't have names in kernel, names
are given in user-space.
