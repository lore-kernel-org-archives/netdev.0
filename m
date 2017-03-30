From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [next-queue v6 PATCH 2/7] i40e: Introduce Port Representor
 netdevs and switchdev mode.
Date: Thu, 30 Mar 2017 12:17:29 +0300
Message-ID: <CAJ3xEMh6Un8JH3275nxOw25RtBp5KnYX+EMSv84+C_ezpkZGGQ@mail.gmail.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com> <1490833375-2788-3-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:34654 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753690AbdC3JRb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 05:17:31 -0400
Received: by mail-oi0-f53.google.com with SMTP id o67so25012532oib.1
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 02:17:30 -0700 (PDT)
In-Reply-To: <1490833375-2788-3-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 30, 2017 at 3:22 AM, Sridhar Samudrala
<sridhar.samudrala@intel.com> wrote:
> Port Representator netdevs are created for each PF and VF if the switch
> mode is set to 'switchdev'. These netdevs can be used to control and
> configure VFs and PFs when they are moved to a different namespace.
> They enable exposing statistics, configure and monitor link state, mtu,
> filters,fdb/vlan entries etc.


What netdev represents the uplink (wire port) in your impl?
