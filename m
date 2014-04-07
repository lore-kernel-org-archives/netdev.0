From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: proc net statistics
Date: Mon, 07 Apr 2014 19:25:44 +0200
Message-ID: <5342DF98.6070000@redhat.com>
References: <1396867174.6220.4.camel@laptop.site> <CAHA+R7NdyXY4RpqLcrNrUtmWPXNOQmW=ho+QgsGV7DptPOewFg@mail.gmail.com> <1396890659.3063.4.camel@mjolnir.site> <CAHA+R7O+1gP4U-YiBHdJeEO1hvH41NcGoRZ5iW_W25CBaXWbnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Ken O'Brien" <ken@kenobrien.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25286 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754025AbaDGRZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2014 13:25:51 -0400
In-Reply-To: <CAHA+R7O+1gP4U-YiBHdJeEO1hvH41NcGoRZ5iW_W25CBaXWbnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2014 07:19 PM, Cong Wang wrote:
> On Mon, Apr 7, 2014 at 10:10 AM, Ken O'Brien <ken@kenobrien.org> wrote:
>>
>> Ok, so then, is there a way to read per process network statistics in the proc filesystem?
>
> AFAIK, we only have per-socket and per-netdev statistics, there is no
> per-process one, you probably want to try cgroup, or put these processes
> into a namespace.

You can do that with cgroups, e.g. xt_cgroup. Samsung/Tizen OS seems to make
use of this ...

https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=a00e76349f3564bb8129fc0510dfd93248c3084d
