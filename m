From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next v4 1/2] vxlan: introduce vxlan_rdst_append
Date: Mon, 24 Jun 2013 10:21:15 +0300
Message-ID: <CAF1J0HOcUUjga0aO3HxPYx8i5ZuQ738iHjMzsfRGTgFNugG7Kg@mail.gmail.com>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1372004543-24675-2-git-send-email-mike.rapoport@ravellosystems.com>
	<kq8nds$ao1$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog107.obsmtp.com ([74.125.245.82]:53794 "HELO
	na3sys010aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752816Ab3FXHVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 03:21:16 -0400
Received: by mail-oa0-f49.google.com with SMTP id n9so11338214oag.8
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 00:21:15 -0700 (PDT)
In-Reply-To: <kq8nds$ao1$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 24, 2013 at 9:02 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sun, 23 Jun 2013 at 16:22 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>>  {
>>       struct vxlan_rdst *rd;
>>
>>       /* protected by vxlan->hash_lock */
>> -     list_for_each_entry(rd, &f->remotes, list) {
>> +     list_for_each_entry(rd, remotes, list) {
>
> This patch is based on Stephen's patches which are not yet merged into
> net-next, right? If so, I think you have to wait. My IPv6 patches are
> pending because of his patches too.

I know that my patches (as well as OVS pacthes) are getting in the way
of your IPv6 work. I've patiently waited at the beginning of the cycle
for you to merge the IPv6 patches. Afterwards I've waited for Stephen
and David to reach an agreement about the list implementation. So I
think I can send the patches for review without waiting, even although
vxlan-net has not been merged into the net-next yet.

--
Sincerely yours,
Mike.
