From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC iproute2] tc: Show classes in tree view
Date: Fri, 19 Dec 2014 12:02:06 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA0F648@AcuExch.aculab.com>
References: <1418989381-6492-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Vadim Kochan' <vadim4j@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46972 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751890AbaLSMCk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 07:02:40 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 30494-09 for <netdev@vger.kernel.org>;
 Fri, 19 Dec 2014 12:02:32 +0000 (GMT)
In-Reply-To: <1418989381-6492-1-git-send-email-vadim4j@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan
> Added new '-t[ree]' which shows classes dependency
> in the tree view.
...
> @@ -278,6 +279,8 @@ int main(int argc, char **argv)
>  			++show_raw;
>  		} else if (matches(argv[1], "-pretty") == 0) {
>  			++show_pretty;
> +		} else if (matches(argv[1], "-tree") == 0) {
> +			++show_tree;
>  		} else if (matches(argv[1], "-Version") == 0) {
>  			printf("tc utility, iproute2-ss%s\n", SNAPSHOT);
>  			return 0;

Clearly you've followed the old code, but it is much clearer
to assign 1 (or true) rather than doing an increment
(unless you expect '-tree -tree' to do something extra).

I believe the whole business of using 'foo++' to change a 0 to a 1
harks back to the pdp11 where it was a shorter instruction sequence.

	David
