From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Segmentation fault in iproute2 ss -p (versions 4.0.0, 4.1.0 and
 4.1.1)
Date: Mon, 20 Jul 2015 12:09:54 -0700
Message-ID: <20150720120954.2639f2e4@urahara>
References: <20150719140548.6d17a475@urahara>
	<55AC9E25.9050804@openmailbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "j.ps@openmailbox.org" <j.ps@openmailbox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34728 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbbGTTJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 15:09:45 -0400
Received: by pacan13 with SMTP id an13so106550236pac.1
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 12:09:45 -0700 (PDT)
In-Reply-To: <55AC9E25.9050804@openmailbox.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches are always appreciated and this looks like a real bug.
But before I can accept it there are a couple of small
changes needed.

1. There is no need to check for NULL when calling free().
   Glibc free is documented to accept NULL as a valid request
   and do nothing.

2. Please add a Signed-off-by: line with a real name.
   Signed-off-by has legal meaning for the Developer's Certificate of Origin
   see kernel documentation if you need more explaination.

3. Although what you found is important, giving a full paragraph
   of personal comment about it is not required. The point is software
   should read like one source independent of who the authors are.
   Your comment is basically just justifying using strncpy.

4. Rather than strncpy() which has issues with maximal sized strings
   consider using strlcpy() instead.

5. Iproute2 uses kernel identation and style, consider running checkpatch
   on your changes.

Please fixup and resubmit to netdev.
