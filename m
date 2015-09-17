From: Jiri Benc <jbenc@redhat.com>
Subject: Re: list of all network namespaces
Date: Thu, 17 Sep 2015 20:14:50 +0200
Message-ID: <20150917201450.02c9586c@griffin>
References: <CAOxq_8Noj5oxPY5BEsWL6u4h_AD+oXYS+JCRGES_gmMQKd0rOQ@mail.gmail.com>
	<55FA0F4A.3010105@hp.com>
	<9B0331B6EBBD0E4684FBFAEDA55776F919440808@HASMSX110.ger.corp.intel.com>
	<CAOxq_8OTR2neJhDU4BOubWcc7Qd=j9T3jg4ESv-ojXqj+xxYxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rosen, Rami" <rami.rosen@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35193 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582AbbIQSOz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 14:14:55 -0400
In-Reply-To: <CAOxq_8OTR2neJhDU4BOubWcc7Qd=j9T3jg4ESv-ojXqj+xxYxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Sep 2015 10:39:57 -0700, Ani Sinha wrote:
> Will there be any interest if I cook up a kernel patch that lists all
> network namespaces through /proc?

/proc is a wrong interface for this, enumerating all net namespaces has
nothing to do with processes. Each process has its corresponding
namespaces in /proc already listed, which is as much as belongs
to /proc.

Dumping all net namespaces should be probably netlink based but
obviously, you'll have hard time sending file descriptors over netlink.
You can dump their netnsids but that won't help you much accessing the
namespace contents.

This is not as easy as it seems. But I'd love to have such feature.

 Jiri

-- 
Jiri Benc
