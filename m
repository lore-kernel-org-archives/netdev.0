From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 02/27] ip: add new command line argument -json (mutually
 exclusive with -color)
Date: Thu, 3 Aug 2017 09:17:45 -0700
Message-ID: <20170803091745.6c028270@xeon-e3>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
        <20170803155515.99226-3-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, dsa@cumulusnetworks.com
To: Julien Fortin <julien@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:38886 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751244AbdHCQRs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:17:48 -0400
Received: by mail-pg0-f46.google.com with SMTP id l64so8025068pge.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 09:17:48 -0700 (PDT)
In-Reply-To: <20170803155515.99226-3-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  3 Aug 2017 17:54:50 +0200
Julien Fortin <julien@cumulusnetworks.com> wrote:

> @@ -292,6 +295,9 @@ int main(int argc, char **argv)
>  
>  	_SL_ = oneline ? "\\" : "\n";
>  
> +	if (json)
> +		disable_color();

Probably better to error out if user gives -j and -c
